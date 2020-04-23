require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord

    #### Attributes ####

    #### Instance Methods ####
    def initialize(options={})
        options.each {|prop, value| self.send("#{prop}=", value)}
    end

    def table_name_for_insert
        self.class.table_name
    end

    def col_names_for_insert
        self.class.column_names.delete_if {|col| col == "id"}.join(", ")
    end

    def values_for_insert
        values = []
        self.class.column_names.each do |col_name|
            values << "'#{send(col_name)}'" unless send(col_name).nil?
        end
        values.join(", ")
    end

    def save
        sql = <<-SQL
            INSERT INTO #{table_name_for_insert}(#{col_names_for_insert})
            VALUES (#{values_for_insert})
            SQL
        DB[:conn].execute(sql)
        @id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
    end

    #### Class Methods####
    def self.table_name
        self.to_s.downcase.pluralize
    end

    def self.column_names
        DB[:conn].results_as_hash = true
        returned_column_names = []

        sql = "pragma table_info('#{table_name}')"

        table_info = DB[:conn].execute(sql)
        table_info.each do |row|
            returned_column_names << row["name"]
        end
        returned_column_names.compact
    end

    def self.find_by_name(name)
        sql = <<-SQL
            SELECT *
            FROM #{table_name}
            WHERE name = ?
            SQL
        DB[:conn].execute(sql, name)
    end

    def self.find_by(hash)
        sql = <<-SQL
            SELECT *
            FROM #{table_name}
            WHERE #{hash.keys[0].to_s} = ?
            SQL
        DB[:conn].execute(sql, hash.values[0].to_s)
    end
end
