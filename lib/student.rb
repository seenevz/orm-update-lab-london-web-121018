require_relative "../config/environment.rb"

class Student

  attr_accessor :name, :grade
  attr_reader :id

  def initialize(id=nil, name, grade)
    @id = id
    @name = name
    @grade = grade
  end

  def self.create_table
    sql = <<-SQL
          create table students (
            id integer primary key,
            name text,
            grade integer
          );
          SQL

    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
          drop table students;
          SQL

    DB[:conn].execute(sql)
  end

  def save
    if self.id
      self.update
    else
      sql = <<-SQL
          insert into students (name, grade) values (?, ?)
          SQL

        DB[:conn].execute(sql, self.name, self.grade)

        @id = DB[:conn].execute("select last_insert_rowid() from students")[0][0]
      end
  end

  def self.create(name, album)
      new_s = Student.new(name, album)
      new_s.save
      new_s
  end

  def self.new_from_db(row)
    id = row[0]
    name = row[1]
    grade = row[2]
    student = self.new(id, name, grade)
  end

  def self.find_by_name(name)
    sql = <<-SQL
        select * from students
        where name = ?
        limit 1
        SQL

    result = DB[:conn].execute(sql, name).flatten
    self.new_from_db(result)
  end

  def update
    sql = "update students set name = ?, grade = ? where id = ?"
    DB[:conn].execute(sql, self.name, self.grade, self.id)
  end



end
