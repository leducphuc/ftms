class LogService
  attr_accessor :model_name, :log_filename, :logfile,
    :number_success, :number_fails

  def initialize args
    @model_name = args[:model_name]
    @log_filename = args[:log_filename]
    @number_success = 0
    @number_fails = 0

    dir = File.dirname("#{Rails.root}/log/imports/#{@log_filename}.log")

    FileUtils.mkdir_p(dir) unless File.directory?(dir)
    @logfile ||= Logger.new("#{Rails.root}/log/imports/#{@log_filename}.log")
  end

  def write_success_log model_attributes
    write_info "#{model_attributes} was imported successfully"
  end

  def write_fails_log model_attributes
    write_error "#{model_attributes} was imported fail"
  end

  def write_total_number_log
    write_total "#{@number_success} records was imported, #{@number_fails} records counldn't import"
  end

  def write_info content
    @logfile.info content
    @number_success += 1
  end

  def write_error content
    @logfile.error content
    @number_success += 1
  end

  def write_total content
    @logfile.fatal content
  end
end
