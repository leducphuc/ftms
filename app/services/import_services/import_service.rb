class ImportServices::ImportService
  attr_accessor :file_path, :model, :attributes, :verify_attribute, :type

  def initialize args
    @file_path = args[:file_path]
    @model = args[:model]
    @verify_attribute = args[:verify_attribute]
    @data_type = args[:data_type]
    @logfile = args[:logfile]
    @numbers_success = 0
    @numbers_fail = 0
  end

  def valid?
    File.exists?(@file_path) && correct_file_type?
  end

  def save
    save_from_csv if is_csv?
  end

  private
  def find_columns
    Settings.import.to_hash.detect{|key, _| key.to_s == @model.to_s.downcase}[1]
  end

  def correct_file_type?
    extension = File.extname @file_path
    Settings.import.file_types.include? extension
  end


  def csv_data_type_valid?
    csv_headers = Set.new CSV.open(@file_path, "r"){|csv| csv.first}
    model_attributes = Set.new model.send(:new).attributes.keys
    if model.send :const_defined?, :CSV_REJECT_ATTRIBUTES
      model_attributes -= Set.new model::CSV_REJECT_ATTRIBUTES
    end
    model_attributes.subset? csv_headers
  end

  def save_from_sheet
    header = CSV.open(@file_path, "r") {|csv| csv.first}
    if check_right_model header, @data_type
      CSV.foreach @file_path, {headers: :first_row} do |row|
        save_object get_object_attributes(row)
      end
      @logfile.write_total_number_log @numbers_success, @numbers_fail
    end
  end

  def save_object model_attributes
    model_attributes.delete :id

    if @object = @model.send(:find_by, @verify_attribute => model_attributes[@verify_attribute])
      @object.send(:update_attributes!, model_attributes) ? write_success_log(model_attributes) :
        write_fails_log(model_attributes)
    else
      @model.send(:create!, model_attributes) ? write_success_log(model_attributes) : write_fails_log(model_attributes)
    end
  end

  def get_object_attributes data
    model_attributes = {}
    find_columns.each {|key, val| model_attributes[key.to_sym] = data[val]}
    model_attributes
  end

  def check_right_model header, data_type
    case data_type
    when Settings.data_types_import.employee
      header.include? Settings.collum_check_import.employee
    end
  end

  def write_success_log model_attributes
    @logfile.write_success_log model_attributes
    @numbers_success += 1
  end

  def write_fails_log model_attributes
    @logfile.write_fails_log model_attributes
    @numbers_fails += 1
  end
end
