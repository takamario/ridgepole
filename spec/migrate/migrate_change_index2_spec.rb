describe 'Ridgepole::Client#diff -> migrate' do
  context 'when change index (no change)' do
    let(:actual_dsl) {
      <<-RUBY
        create_table "salaries", id: false, force: :cascade do |t|
          t.integer "emp_no",    null: false
          t.integer "salary",    null: false
          t.date    "from_date", null: false
          t.date    "to_date",   null: false
        end

        add_index "salaries", ["emp_no"], name: "emp_no", using: :btree
      RUBY
    }

    let(:expected_dsl) {
      <<-RUBY
        create_table "salaries", id: false, force: :cascade do |t|
          t.integer "emp_no",    null: false
          t.integer "salary",    null: false
          t.date    "from_date", null: false
          t.date    "to_date",   null: false
        end

        add_index "salaries", "emp_no", name: "emp_no", using: :btree
      RUBY
    }

    before { subject.diff(actual_dsl).migrate }
    subject { client }

    it {
      delta = subject.diff(expected_dsl)
      expect(delta.differ?).to be_falsey
    }
  end

  context 'when change index (change)' do
    let(:actual_dsl) {
      <<-RUBY
        create_table "salaries", id: false, force: :cascade do |t|
          t.integer "emp_no",    limit: 4, null: false
          t.integer "salary",    limit: 4, null: false
          t.date    "from_date",           null: false
          t.date    "to_date",             null: false
        end

        add_index "salaries", ["emp_no"], name: "emp_no", using: :btree
      RUBY
    }

    let(:dsl) {
      <<-RUBY
        create_table "salaries", id: false, force: :cascade do |t|
          t.integer "emp_no",    null: false
          t.integer "salary",    null: false
          t.date    "from_date", null: false
          t.date    "to_date",   null: false
        end

        add_index "salaries", "salary", name: "emp_no", using: :btree
      RUBY
    }

    let(:expected_dsl) {
      <<-RUBY
        create_table "salaries", id: false, force: :cascade do |t|
          t.integer "emp_no",    limit: 4, null: false
          t.integer "salary",    limit: 4, null: false
          t.date    "from_date",           null: false
          t.date    "to_date",             null: false
        end

        add_index "salaries", ["salary"], name: "emp_no", using: :btree
      RUBY
    }

    before { subject.diff(actual_dsl).migrate }
    subject { client }

    it {
      delta = subject.diff(dsl)
      expect(delta.differ?).to be_truthy
      expect(subject.dump.delete_empty_lines).to eq actual_dsl.strip_heredoc.strip.delete_empty_lines
      delta.migrate
      expect(subject.dump.delete_empty_lines).to eq expected_dsl.strip_heredoc.strip.delete_empty_lines
    }
  end
end