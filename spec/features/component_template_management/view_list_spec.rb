require 'rails_helper'

RSpec.feature 'Component Template Management', type: :feature do
  let(:user_a) { create(:user) }

  before(:each) do
    set_check_user_groups({ 'groups' => [] })

    @component_template = create(:component_template)
  end

  describe 'View component template lists' do
    context 'As Superadmin' do
      scenario 'User can see list of component templates' do
        set_check_user_groups({ 'groups': ['barito-superadmin'] })
        create(:group, name: 'barito-superadmin')
        login_as user_a

        visit component_templates_path
        expect(page).to have_content(@component_template.name)
      end
    end
  end
end
