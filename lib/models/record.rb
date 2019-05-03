class Record
  def initialize(attributes = {})
    create_accessors
    set_attributes(attributes)
  end

  def self.attr_accessor(*vars)
    @attributes ||= []
    @attributes.concat vars
    super(*vars)
  end

  def self.attributes
    @attributes
  end

  def attributes
    self.class.attributes
  end

  def self.create(attributes = {})
    new(attributes).save
  end

  def update(attributes = {})
    attributes.delete(:id)
    set_attributes(attributes)
    save
  end

  # Create / Update
  def save
    if @id.nil?
      # 1. Create
      DB.execute(build_insert_query)
      @id = DB.last_insert_row_id
    else
      # 2. Update
      DB.execute(build_update_query, *row_values)
    end
  end

  # Read
  def self.find(id)
    result = DB.execute("SELECT * FROM #{table_name} WHERE id = ?", id).first
    result.nil? ? nil : build_record(result)
  end

  def self.all
    rows = DB.execute("SELECT * FROM #{table_name}")

    return [] if rows.empty?

    rows.map { |row| build_record(row) }
  end

  # Destroy
  def destroy
    DB.execute("DELETE FROM #{table_name} WHERE id = ?", @id)
    nil
  end

  private

  def self.build_record(row)
    new(row.transform_keys!(&:to_sym))
  end

  def build_insert_query
    "INSERT INTO #{table_name} (#{row_headers.join(',')}) VALUES (#{insert_row(row_values).join(',')})"
  end

  def build_update_query
    "UPDATE #{table_name} SET #{update_statement} WHERE id = #{@id}"
  end

  def create_accessors
    self.class.table_columns.each { |c| self.class.__send__(:attr_accessor, c) }
  end

  def set_attributes(attributes)
    attributes.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  def self.table_columns
    DB.execute("PRAGMA table_info(#{table_name})").map { |a| a[1].to_sym }
  end

  def row_headers
    attributes.reject{ |attr| attr == :id }
  end

  def row_values
    row_headers.map { |attr| convert_value(self.send(attr))}
  end

  def update_statement
    row_headers.map { |attr| "#{attr} = ?" }.join(',')
  end

  def self.table_name
    to_s.gsub(/([a-z\d])([A-Z])/,'\1_\2').downcase + 's'
  end

  def table_name
    self.class.table_name
  end

  def insert_row(values)
    values.map do |v|
      next unless v.is_a? String

      "'#{v}'"
    end
  end

  def convert_value(value)
    case value
    when "True"
      "1"
    when "False"
      "0"
    else
      value
    end
  end
end
