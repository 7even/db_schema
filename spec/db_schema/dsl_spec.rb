require 'spec_helper'

RSpec.describe DbSchema::DSL do
  describe '#schema' do
    let(:schema_block) do
      -> (db) do
        db.table :users do |t|
          t.integer :id, primary_key: true
          t.varchar :name, null: false
          t.varchar :email, default: 'mail@example.com'
          t.char    :sex

          t.index :email, name: :users_email_idx, unique: true, where: 'email IS NOT NULL'
        end

        db.table :posts do |t|
          t.integer :id, primary_key: true
          t.varchar :title
          t.integer :user_id
          t.varchar :user_name

          t.index :user_id, name: :posts_user_id_idx

          t.foreign_key :user_id, references: :users, on_delete: :set_null, deferrable: true
          t.foreign_key :user_name, references: [:users, :name], name: :user_name_fkey, on_update: :cascade
        end
      end
    end

    subject { DbSchema::DSL.new(schema_block) }

    it 'returns an array of Definitions::Table instances' do
      users, posts = subject.schema

      expect(users.name).to eq(:users)
      expect(users.fields.count).to eq(4)
      expect(posts.name).to eq(:posts)
      expect(posts.fields.count).to eq(4)

      id, name, email, sex = users.fields

      expect(id).to be_a(DbSchema::Definitions::Field::Integer)
      expect(id.name).to eq(:id)
      expect(id).to be_primary_key

      expect(name).to be_a(DbSchema::Definitions::Field::Varchar)
      expect(name.name).to eq(:name)
      expect(name).not_to be_null

      expect(email).to be_a(DbSchema::Definitions::Field::Varchar)
      expect(email.name).to eq(:email)
      expect(email.default).to eq('mail@example.com')

      expect(sex).to be_a(DbSchema::Definitions::Field::Char)
      expect(sex.name).to eq(:sex)
      expect(sex.options[:length]).to eq(1)

      expect(users.indices.count).to eq(1)
      email_index = users.indices.first
      expect(email_index.name).to eq(:users_email_idx)
      expect(email_index.fields).to eq([:email])
      expect(email_index).to be_unique
      expect(email_index.condition).to eq('email IS NOT NULL')

      expect(posts.indices.count).to eq(1)
      user_id_index = posts.indices.first
      expect(user_id_index.name).to eq(:posts_user_id_idx)
      expect(user_id_index.fields).to eq([:user_id])
      expect(user_id_index).not_to be_unique

      expect(posts.foreign_keys.count).to eq(2)
      user_id_fkey, user_name_fkey = posts.foreign_keys
      expect(user_id_fkey.name).to eq(:posts_user_id_fkey)
      expect(user_id_fkey.fields).to eq([:user_id])
      expect(user_id_fkey.table).to eq(:users)
      expect(user_id_fkey.references_primary_key?).to eq(true)
      expect(user_id_fkey.on_delete).to eq(:set_null)
      expect(user_id_fkey.on_update).to eq(:no_action)
      expect(user_id_fkey).to be_deferrable
      expect(user_name_fkey.name).to eq(:user_name_fkey)
      expect(user_name_fkey.fields).to eq([:user_name])
      expect(user_name_fkey.table).to eq(:users)
      expect(user_name_fkey.keys).to eq([:name])
      expect(user_name_fkey.on_delete).to eq(:no_action)
      expect(user_name_fkey.on_update).to eq(:cascade)
      expect(user_name_fkey).not_to be_deferrable
    end
  end
end
