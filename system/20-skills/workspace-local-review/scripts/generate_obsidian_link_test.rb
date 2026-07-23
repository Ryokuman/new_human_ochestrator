#!/usr/bin/env ruby
# frozen_string_literal: true

require "base64"
require "fileutils"
require "open3"
require "tmpdir"
require "uri"

script = File.expand_path("generate-obsidian-link.rb", __dir__)

Dir.mktmpdir do |workspace|
  extensions_dir = File.join(workspace, "extensions")
  FileUtils.mkdir_p(File.join(extensions_dir, "stefansteinert.vscode-obsidian-links-0.1.3"))
  review_dir = File.join(workspace, "local", "sample")
  FileUtils.mkdir_p(review_dir)
  note = File.join(review_dir, "검수 문서.md")
  File.write(note, "# 검수\n")

  stdout, stderr, status = Open3.capture3(
    "ruby", script, "--workspace-root", workspace,
    "--extensions-dir", extensions_dir,
    "--label", "Obsidian에서 검수하기", note
  )
  raise stderr unless status.success?

  href = stdout[/\((vscode:\/\/[^)]+)\)/, 1]
  raise "vscode link missing" unless href

  encoded = URI.decode_www_form(URI.parse(href).query).to_h.fetch("href_b64")
  obsidian_uri = Base64.strict_decode64(encoded)
  expected_path = URI.encode_www_form_component(File.expand_path(note)).gsub("+", "%20")
  raise "round trip mismatch" unless obsidian_uri == "obsidian://open?path=#{expected_path}"

  outside = File.join(Dir.tmpdir, "outside-review-#{Process.pid}.md")
  File.write(outside, "# outside\n")
  _out, _err, outside_status = Open3.capture3(
    "ruby", script, "--workspace-root", workspace,
    "--extensions-dir", extensions_dir, outside
  )
  File.delete(outside)
  raise "outside path accepted" if outside_status.success?

  _out, _err, missing_status = Open3.capture3(
    "ruby", script, "--workspace-root", workspace,
    "--extensions-dir", extensions_dir, File.join(workspace, "missing.md")
  )
  raise "missing path accepted" if missing_status.success?

  missing_extensions_dir = File.join(workspace, "missing-extensions")
  FileUtils.mkdir_p(missing_extensions_dir)
  _out, extension_error, extension_status = Open3.capture3(
    "ruby", script, "--workspace-root", workspace,
    "--extensions-dir", missing_extensions_dir, note
  )
  raise "missing extension accepted" if extension_status.success?
  raise "missing extension guidance absent" unless extension_error.include?("StefanSteinert.vscode-obsidian-links")
end

puts "generate obsidian link test passed"
