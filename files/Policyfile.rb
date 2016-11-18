# frozen_string_literal: true
name 'workup'

default_source :community

run_list(
  # This stops the Policyfile from complaining
  'nop'
)
