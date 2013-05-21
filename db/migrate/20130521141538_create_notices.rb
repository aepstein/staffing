class CreateNotices < ActiveRecord::Migration
  MAP = { 'Membership' => %w( join leave decline ),
          'MembershipRequest' => %w( reject close ),
          'User' => %w( renew ) }

  def up
    create_table :notices do |t|
      t.integer :notifiable_id, null: false
      t.string :notifiable_type, null: false
      t.string :event, null: false
      t.datetime :archived_at
      t.datetime :created_at, null: false
    end
    add_index :notices, [ :notifiable_id, :notifiable_type ]
    add_index :notices, [ :notifiable_type, :event ]
    say_with_time "Moving notices to separate table" do
      MAP.each do |type, events|
        events.each do |event|
          execute <<-SQL
            INSERT INTO notices ( notifiable_id, notifiable_type, event,
              created_at )
            SELECT id, '#{type}', '#{event}', #{event}_notice_at FROM
              #{type.underscore.pluralize} WHERE #{event}_notice_at IS NOT NULL
          SQL
        end
      end
    end
  end
  
  def down
    say_with_time "Moving notices back from separate table" do
      MAP.each do |type, events|
        events.each do |event|
          execute <<-SQL
            UPDATE #{type.underscore.pluralize} SET #{event}_notice_at = 
              (SELECT MAX(created_at) FROM 
                 notices WHERE notices.notifiable_type = '#{type}' AND
                 notices.notifiable_id = #{type.underscore.pluralize}.id AND
                 notices.event = '#{event}' )
          SQL
        end
      end
    end
    remove_index :notices, [ :notifiable_type, :event ]
    remove_index :notices, [ :notifiable_id, :notifiable_type ]
    drop_table :notices
  end
end
