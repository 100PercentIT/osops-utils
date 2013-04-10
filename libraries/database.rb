module RCB
  def create_db_and_user(db, db_name, username, pw)
    db_info = nil
    case db
      when "mysql"
        connect_host = get_access_endpoint("mysql-master", "mysql", "db")["host"]
        mysql_info = get_settings_by_role('mysql-master', 'mysql')
        connection_info = {:host => connect_host, :username => "root", :password => mysql_info["server_root_password"] }

        # create database
        mysql_database "create #{db_name} database" do
          connection connection_info
          database_name db_name
          action :create
        end

        # create user
        mysql_database_user username do
          connection connection_info
          password pw
          action :create
        end

        # grant privs to user
        mysql_database_user username do
          connection connection_info
          password pw
          database_name db_name
          host '%'
          privileges [:all]
          action :grant
        end
        db_info = mysql_info
      when "postgresql"
        postgresql_info = get_settings_by_role('postgresql-master', 'postgresl')
        connection_info = {:host => "127.0.0.1",
                                      :port => node['postgresql']['config']['port'],
                                      :username => 'postgres',
                                      :password => node['postgresql']['password']['postgres']}

        # create database
        postgresql_database "create #{db_name} database" do
          connection connection_info
          database_name db_name
          action :create
        end

        postgresql_database_user username do
          connection connection_info
          password pw
          action :create
        end

        postgresql_database_user username do
          connection connection_info
          password pw
          database_name db_name
          host '%'
          privileges [:all]
          action :grant
        end
        db_info = postgresql_info
    end
    db_info
  end
end
