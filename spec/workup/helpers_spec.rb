# frozen_string_literal: true
require 'spec_helper'

describe Workup::Helpers do
  it 'checks the user' do
    expect { Workup::Helpers.check_user! }.not_to raise_error
  end
end
