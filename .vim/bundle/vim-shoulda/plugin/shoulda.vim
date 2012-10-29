function! s:ShouldaBufSyntax()
  if (!exists("g:rails_syntax") || g:rails_syntax)
    let t = RailsFileType()
    if &syntax == 'ruby'
      if t =~ '^test'
        syn keyword rubyRailsTestMethod assert_bad_value assert_contains
        syn keyword rubyRailsTestMethod assert_did_not_send_email assert_does_not_contain assert_good_value
        syn keyword rubyRailsTestMethod assert_same_elements assert_save assert_sent_email assert_valid
        syn keyword rubyRailsTestMethod pretty_error_messages report!

        syn keyword rubyTodo should_eventually

        syn keyword rubyRailsTestMacro should context setup teardown
      endif
      if t =~ '^test-unit'
        syn keyword rubyRailsTestMacro should_allow_values_for should_belong_to should_ensure_length_at_least 
        syn keyword rubyRailsTestMacro should_ensure_length_in_range should_ensure_length_is should_ensure_value_in_range 
        syn keyword rubyRailsTestMacro should_have_and_belong_to_many should_have_class_methods should_have_db_column 
        syn keyword rubyRailsTestMacro should_have_db_columns should_have_index should_have_indices 
        syn keyword rubyRailsTestMacro should_have_instance_methods should_have_many should_have_named_scope 
        syn keyword rubyRailsTestMacro should_have_one should_have_readonly_attributes should_not_allow_values_for 
        syn keyword rubyRailsTestMacro should_only_allow_numeric_values_for should_protect_attributes 
        syn keyword rubyRailsTestMacro should_require_acceptance_of should_require_attributes 
        syn keyword rubyRailsTestMacro should_require_unique_attributes  
      elseif t=~ '^test-functional'
        syn keyword rubyRailsTestMethod assert_xml_response request_xml 

        syn keyword rubyRailsTestMacro should_assign_to should_be_restful should_not_assign_to should_not_set_the_flash
        syn keyword rubyRailsTestMacro should_redirect_to should_render_a_form should_render_template should_respond_with
        syn keyword rubyRailsTestMacro should_set_the_flash_to should_respond_with_xml 
        syn keyword rubyRailsTestMacro should_respond_with_xml_for
      endif
    endif
  endif
endfunction

augroup railsPluginDetect
  autocmd Syntax ruby if exists("b:rails_root") | call s:ShouldaBufSyntax() | endif
augroup END
