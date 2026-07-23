#!/usr/bin/env ruby
# frozen_string_literal: true

module TaskStatusPaths
  STATUSES = %w[todo in_progress blocked review done].freeze
  TEMPLATE_DIRECTORY = "_templates"

  module_function

  def frontmatter(path)
    lines = File.readlines(path, encoding: "UTF-8")
    return {} unless lines.first&.strip == "---"

    closing = lines[1..].index { |line| line.strip == "---" }
    return {} unless closing

    lines[1, closing].each_with_object({}) do |line, values|
      key, value = line.split(":", 2)
      next unless value

      values[key.strip] = value.strip.sub(/\A(["'])(.*)\1\z/, "\\2")
    end
  end

  def task_files(root)
    Dir.glob(File.join(root, "**", "*.md")).reject do |path|
      path.split(File::SEPARATOR).include?(TEMPLATE_DIRECTORY)
    end.select do |path|
      frontmatter(path)["type"] == "task"
    end.sort
  end

  def validate(root)
    errors = []
    files = task_files(root)

    files.each do |path|
      directory_status = File.basename(File.dirname(path))
      status = frontmatter(path)["status"]
      relative = path.delete_prefix("#{root}/")

      unless STATUSES.include?(directory_status)
        errors << "#{relative}: 허용된 상태 디렉터리 밖에 있습니다"
        next
      end

      if status.nil? || status.empty?
        errors << "#{relative}: frontmatter status가 없습니다"
      elsif !STATUSES.include?(status)
        errors << "#{relative}: 허용되지 않은 frontmatter status #{status}입니다"
      elsif directory_status != status
        errors << "#{relative}: 경로 상태 #{directory_status}와 frontmatter status #{status}가 다릅니다"
      end
    end

    [files.length, errors]
  end
end

if $PROGRAM_NAME == __FILE__
  root = ARGV.fetch(0) do
    warn "사용법: ruby system/20-skills/projects-setup/scripts/validate-task-status-paths.rb <tasks-directory>"
    exit 2
  end

  unless Dir.exist?(root)
    warn "Task 디렉터리를 찾을 수 없습니다: #{root}"
    exit 2
  end

  count, errors = TaskStatusPaths.validate(File.expand_path(root))
  if errors.empty?
    puts "Task 상태 경로 검증 통과: #{count}개"
    exit 0
  end

  errors.each { |error| warn error }
  warn "Task 상태 경로 검증 실패: #{errors.length}건"
  exit 1
end
