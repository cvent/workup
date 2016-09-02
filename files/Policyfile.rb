name 'workup'

default_source :community

cookbook 'no_op', github: 'livinginthepast/windows-noop-cookbook'

run_list(
  # This stops the Policyfile from complaining
  'no_op'
)
