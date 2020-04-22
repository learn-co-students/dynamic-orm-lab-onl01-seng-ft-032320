require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

  def self.table_name
    self.to_s.downcase.pluralize # returns  "songs"
  end

  def self.column_names
    DB[:conn].results_as_hash = true

    sql = "pragma table_info('#{self.table_name}')"

    table_info = DB[:conn].execute(sql)
    column_names = []
    table_info.each {|column|
      column_names << column["name"]
    }
    column_names.compact
  end

  def initialize(options={})
    options.each { |property, value|
      self.send(("#{property}="), value)
    }
  end

  def table_name_for_insert
    self.class.table_name #"songs"
  end

  def col_names_for_insert
    self.class.column_names.delete_if { |column| column == "id"}.join(", ") # "name, grade"
  end

# INSERT INTO TABLE songs(name, grade) VALUES("Tom", "10")

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?

    end
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{self.table_name_for_insert}(#{self.col_names_for_insert}) VALUES(#{self.values_for_insert})"
    DB[:conn].execute(sql)
    @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"

    DB[:conn].execute(sql, name)

  end

  def self.find_by(attribute)
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute.keys[0]} = ?"
    result = DB[:conn].execute(sql, attribute.values[0])
    #binding.pry
  end


end
