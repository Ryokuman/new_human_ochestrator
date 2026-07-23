#!/usr/bin/env ruby
# frozen_string_literal: true

require "base64"
require "open3"
require "optparse"
require "pathname"
require "uri"

extension_id = "StefanSteinert.vscode-obsidian-links"
options = { workspace_root: Dir.pwd, label: "Obsidian에서 열기", extensions_dirs: [] }
OptionParser.new do |parser|
  parser.on("--workspace-root PATH") { |value| options[:workspace_root] = value }
  parser.on("--label TEXT") { |value| options[:label] = value }
  parser.on("--extensions-dir PATH") { |value| options[:extensions_dirs] << value }
end.parse!

abort "사용법: generate-obsidian-link.rb [--workspace-root PATH] [--label TEXT] FILE" unless ARGV.length == 1

workspace = Pathname.new(options[:workspace_root]).expand_path.cleanpath
target = Pathname.new(ARGV.fetch(0)).expand_path.cleanpath
abort "대상 Markdown 파일이 없습니다: #{target}" unless target.file?

extension_installed = false
if options[:extensions_dirs].empty?
  begin
    stdout, _stderr, status = Open3.capture3("code", "--list-extensions")
    extension_installed = status.success? && stdout.lines.any? { |line| line.strip.casecmp?(extension_id) }
  rescue Errno::ENOENT
    extension_installed = false
  end
end

extension_dirs = options[:extensions_dirs]
if extension_dirs.empty?
  extension_dirs = [
    ENV["VSCODE_EXTENSIONS"],
    File.join(Dir.home, ".vscode", "extensions"),
    File.join(Dir.home, ".vscode-insiders", "extensions")
  ].compact
end

extension_installed ||= extension_dirs.any? do |directory|
  next false unless Dir.exist?(directory)

  Dir.children(directory).any? do |entry|
    normalized = entry.downcase
    normalized == extension_id.downcase || normalized.start_with?("#{extension_id.downcase}-")
  end
end

unless extension_installed
  abort "VS Code 확장이 필요합니다: #{extension_id}"
end

workspace_prefix = "#{workspace}#{File::SEPARATOR}"
unless target.to_s.start_with?(workspace_prefix)
  abort "대상 파일이 workspace vault 밖에 있습니다: #{target}"
end

encoded_path = URI.encode_www_form_component(target.to_s).gsub("+", "%20")
obsidian_uri = "obsidian://open?path=#{encoded_path}"
href_b64 = Base64.strict_encode64(obsidian_uri)
vscode_uri = "vscode://StefanSteinert.vscode-obsidian-links/open?href_b64=#{href_b64}"

puts "[#{options[:label]}](#{vscode_uri})"
