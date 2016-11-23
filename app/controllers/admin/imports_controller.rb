class Admin::ImportsController < ApplicationController
  def index
    if params[:filename]
      if @filename = Dir["#{Rails.root}/log/imports/#{params[:filename]}.log"].first
        @file = File.open(@filename)
      else
        redirect_to admin_imports_path, alert: flash_message("import.no_log")
      end
    end

  end

  def create
    if params[:type].present?
      params[:type].each_with_index do |data_type, index|
        log_filename = new_log_file data_type.capitalize.pluralize

        model = find_model data_type
        import = "ImportServices::Import#{model}".constantize.new model: model.constantize,
          file_path: params[:file][index].tempfile.path.to_s,
          verify_attribute: find_verify_attribute(data_type),
          data_type: data_type,
          logfile: @logfile
        if import.valid?
          import.perform
          @logfile.write_total_number_log
        end
        redirect_to admin_imports_path filename: log_filename
      end
    else
      redirect_to admin_imports_path, alert: flash_message("import.no_select_file")
    end
  end

  private
  def find_model data_type
    data_type.split("_").each {|word| word.capitalize!}.join("")
  end

  def find_verify_attribute model
    Settings.import.data_types.detect{|data_type| data_type.model == model}
      .verify_attribute.to_sym
  end

  def new_log_file model_name
    current_time = Time.now.strftime t("datetime.formats.time_log")
    current_user_name = current_user.name.gsub(" ", "-").downcase
    log_filename = "#{current_user_name}_import_#{model_name}_at_#{current_time}"

    @logfile = LogService.new model_name: model_name, current_user: current_user,
      log_filename: log_filename
    log_filename
  end
end
