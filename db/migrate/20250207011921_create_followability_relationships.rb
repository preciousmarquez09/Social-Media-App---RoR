class CreateFollowabilityRelationships < ActiveRecord::Migration[6.0]
  def change
    create_table :followability_relationships do |t|
      t.belongs_to :followerable, polymorphic: true, null: false, index: { name: "index_follow_rel_on_followerable" }
      t.belongs_to :followable, polymorphic: true, null: false, index: { name: "index_follow_rel_on_followable" }
      t.integer :status
    end
  end
end
