class DropMeetingMotions < ActiveRecord::Migration
  def up
    execute <<-SQL
      INSERT INTO meeting_sections (meeting_id, name, position,
        created_at, updated_at)
      SELECT DISTINCT meeting_id,
        "Business of the Day",
        (SELECT IF(MAX(position), MAX(position)+1, 1) FROM meeting_sections
         WHERE meeting_id = meeting_motions.meeting_id) AS position,
        MIN(created_at),
        MAX(updated_at)
        FROM meeting_motions GROUP BY meeting_id
    SQL
    execute <<-SQL
      INSERT INTO meeting_items (meeting_section_id, motion_id, duration,
        position, updated_at, created_at)
      SELECT DISTINCT meeting_sections.id, motion_id, 1,
        (SELECT COUNT(*) FROM meeting_motions AS priors WHERE
        priors.meeting_id = meeting_motions.meeting_id AND
        priors.id <= meeting_motions.id) AS position,
        meeting_motions.updated_at,
        meeting_motions.created_at
        FROM meeting_motions INNER JOIN meeting_sections
        WHERE meeting_motions.meeting_id = meeting_sections.meeting_id AND
        meeting_sections.name = "Business of the Day"
        ORDER BY meeting_sections.id, position
    SQL
    remove_index :meeting_motions, [ :meeting_id, :motion_id ]
    drop_table :meeting_motions
  end

  def down
    create_table "meeting_motions", :force => true do |t|
      t.integer  "meeting_id",                      :null => false
      t.integer  "motion_id",                       :null => false
      t.text     "comment"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "introduced_version"
      t.string   "introduced_version_content_type"
      t.integer  "introduced_version_file_size"
      t.datetime "introduced_version_updated_at"
      t.string   "final_version"
      t.string   "final_version_content_type"
      t.integer  "final_version_file_size"
      t.datetime "final_version_updated_at"
    end
    add_index "meeting_motions", ["meeting_id", "motion_id"], unique: true
    execute <<-SQL
      INSERT INTO meeting_motions ( meeting_id, motion_id )
      SELECT meeting_id, motion_id, meeting_items.created_at,
        meeting_items.updated_at FROM meeting_items INNER JOIN meeting_sections
        ON meeting_items.meeting_section_id = meeting_sections.meeting_id
        WHERE meeting_items.motion_id IS NOT NULL
        AND meeting_sections.name = "Business of the Day" AND
        meeting_items.duration = 1
        ORDER BY meeting_sections.id, meeting_items.position
    SQL
  end
end

