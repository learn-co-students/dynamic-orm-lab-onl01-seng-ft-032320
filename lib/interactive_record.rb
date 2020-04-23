require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

   def self.table_name
      self.to_s.downcase.pluralize
   end

   def self.column_names
      columns = []
      DB[:conn].results_as_hash = true
      table_info = DB[:conn].execute("PRAGMA table_info('#{table_name}')")
      table_info.each{|info| columns << info["name"]}
      
      columns.compact
   end

   def initialize(student_hash={})
      student_hash.each{|k,v| self.send("#{k}=", v)}
   end

   def table_name_for_insert
      self.class.table_name
   end

   def col_names_for_insert
      cols = self.class.column_names.delete_if{|col| col == "id"}.join(", ")
   end

   def values_for_insert
      values = []
      self.class.column_names.each{|col| values << "'#{send(col)}'" unless send(col).nil?}
      values.join(", ")
   end

   def save
      sql = <<-SQL
      INSERT INTO #{table_name_for_insert} (#{col_names_for_insert})
      VALUES (#{values_for_insert})
      SQL

      DB[:conn].execute(sql)
      @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
   end

   def self.find_by_name(name)
      sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"

      result = DB[:conn].execute(sql)
   end

end