require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject
  def self.columns
    return @columns if @columns
    col = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        #{self.table_name}
    SQL
    @columns =col[0].map {|el| el.to_sym}
  end

  def self.finalize!
    cols = self.columns
    cols.each do |col|
      define_method(col) do
        attributes[col]
        #instance_variable_get("@#{col}")
      end

      define_method("#{col}=") do |value|
        attributes[col] = value
        #instance_variable_set("@#{col}", value)
      end
    end

  end

  def self.table_name=(table_name)
    @table_name = table_name
  end

  def self.table_name
    return @table_name || self.name.tableize
  end

  def self.all
    col = DBConnection.execute(<<-SQL)
      SELECT
      #{table_name}.*
      FROM
      #{table_name}
    SQL
    parse_all(col)
  end

  def self.parse_all(results)
    return results.map do |el|
      self.new(el)
    end
  end

  def self.find(id)
    col = DBConnection.execute(<<-SQL)
      SELECT
      #{table_name}.*
      FROM
      #{table_name}
      WHERE
      #{table_name}.id = #{id}
    SQL
    return nil if col == []
    return self.new(col[0])
  end

  def initialize(params = {})
    params.each do |k,v|
      raise "unknown attribute '#{k.to_sym}'" if !self.class.columns.include?(k.to_sym)
      self.send(k.to_s + "=",v)
    end
  end

  def attributes
    return @attributes if @attributes
    @attributes = {}
  end

  def attribute_values
    # ...
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
