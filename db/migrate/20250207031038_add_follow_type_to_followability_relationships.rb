class AddFollowTypeToFollowabilityRelationships < ActiveRecord::Migration[6.0]
  def change
    add_column :followability_relationships, :follow_type, :string, default: "follow"
  end
end
