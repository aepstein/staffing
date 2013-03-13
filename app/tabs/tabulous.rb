Tabulous.setup do |config|
  config.tabs do
    basic = [ [ :home_tab, 'Home', home_path, true, true ] ]
    basic += [
      [ :admin_tab                   ,"Administration"   ,users_path              ,permitted_to?(:staff,:users)      ,true ],
      [    :authorities_subtab       ,'Authorities'      ,authorities_path        ,true                ,true        ],
      [    :brands_subtab            ,'Brands'           ,brands_path             ,true                ,true        ],
      [    :positions_subtab         ,'Positions'        ,positions_path          ,true                ,true        ],
      [    :committees_subtab        ,'Committees'       ,committees_path         ,true                ,true        ],
      [    :meeting_templates_subtab ,'Meeting Templates',meeting_templates_path  ,true                ,true        ],
      [    :users_subtab             ,'Users'            ,users_path              ,true                ,true        ],
      [    :questions_subtab         ,'Questions'        ,questions_path          ,true                ,true        ],
      [    :quizzes_subtab           ,'Quizzes'          ,quizzes_path            ,true                ,true        ],
      [    :schedules_subtab         ,'Schedules'        ,schedules_path          ,true                ,true        ],
      [    :meetings_subtab          ,'Meetings'         ,meetings_path           ,true                ,true        ],
      [    :motions_subtab           ,'Motions'          ,motions_path            ,true                ,true        ],
      [    :motions_subtab           ,'Motions'          ,motions_path            ,true                ,true        ]
    ]
    if current_user
      basic += [
        [ :review_tab                  ,"Review"           ,reviewable_memberships_path ,current_user.authorities.prospective.any?, true ],
        [ :active_memberships_subtab   ,"Active Memberships",active_reviewable_memberships_path,true, true],
        [ :active_membership_requests_subtab,"Active Membership Requests",active_reviewable_membership_requests_path,true,true],
        [ :inactive_membership_requests_subtab,"Inactive Membership Requests",inactive_reviewable_membership_requests_path,true,true]
      ]
    end
    basic += [
      [ :logout_tab, 'Log Out', logout_path, current_user.present?, true ],
      [ :login_tab , 'Log In' , login_path , current_user.blank?  , true ]
    ] unless sso_net_id
    basic
  end

  config.actions do
    [
      [ :authorities        ,:all_actions,:authorities_subtab          ],
      [ :brands             ,:all_actions,:brands_subtab               ],
      [ :committees         ,:all_actions,:committees_subtab           ],
      [ :enrollments        ,:all_actions,:admin_tab                   ],
      [ :home               ,:all_actions,:home_tab                    ],
      [ :meetings           ,:all_actions,:meetings_subtab             ],
      [ :meeting_templates  ,:all_actions,:meeting_templates_subtab    ],
      [ :memberships        ,:all_actions,:admin_tab                   ],
      [ :membership_requests,:all_actions,:admin_tab                   ],
      [ :memberships        ,:all_actions,:memberships_tab             ],
      [ :motions            ,:all_actions,:motions_subtab              ],
      [ :positions          ,:all_actions,:positions_subtab            ],
      [ :qualifications     ,:all_actions,:qualifications_tab          ],
      [ :questions          ,:all_actions,:questions_subtab            ],
      [ :quizzes            ,:all_actions,:quizzes_subtab              ],
      [ :schedules          ,:all_actions,:schedules_subtab            ],
      [ :users              ,:all_actions,:users_subtab                ],
      [ :user_sessions      ,:new        ,:login_tab                   ],
      [ :user_sessions      ,:create     ,:login_tab                   ]
    ]
  end

  #---------------------
  #   GENERAL OPTIONS
  #---------------------

  # By default, you cannot click on the active tab.
  config.active_tab_clickable = true

  # By default, the subtabs HTML element is not rendered if it is empty.
  config.always_render_subtabs = false

  # Tabulous expects every controller action to be associated with a tab.
  # When an action does not have an associated tab (or subtab), you can
  # instruct tabulous how to behave:
  config.when_action_has_no_tab = :raise_error      # the default behavior
  # config.when_action_has_no_tab = :do_not_render  # no tab navigation HTML will be generated
  # config.when_action_has_no_tab = :render         # the tab navigation HTML will be generated,
                                                    # but no tab or subtab will be active

  #--------------------
  #   MARKUP OPTIONS
  #--------------------

  # By default, div elements are used in the tab markup.  When html5 is
  # true, nav elements are used instead.
  config.html5 = false

  # This gives you control over what class the <ul> element that wraps the tabs
  # will have.  Good for interfacing with third-party code like Twitter
  # Bootstrap.
  config.tabs_ul_class = "nav nav-pills"

  # This gives you control over what class the <ul> element that wraps the subtabs
  # will have.  Good for interfacing with third-party code.
  # config.subtabs_ul_class = "nav"

  # Set this to true to have subtabs rendered in markup that Twitter Bootstrap
  # understands.  If this is set to true, you don't need to call subtabs in
  # your layout, just tabs.
  config.bootstrap_style_subtabs = true


  #-------------------
  #   STYLE OPTIONS
  #-------------------
  #
  # The markup that is generated has the following properties:
  #
  #   Tabs and subtabs that are selected have the class "active".
  #   Tabs and subtabs that are not selected have the class "inactive".
  #   Tabs that are disabled have the class "disabled"; otherwise, "enabled".
  #   Tabs that are not visible do not appear in the markup at all.
  #
  # These classes are provided to make it easier for you to create your
  # own CSS (and JavaScript) for the tabs.

  # Some styles will be generated for you to get you off to a good start.
  # Scaffolded styles are not meant to be used in production as they
  # generate invalid HTML markup.  They are merely meant to give you a
  # head start or an easy way to prototype quickly.  Set this to false if
  # you are using Twitter Bootstrap.
  #
  config.css.scaffolding = false

  # You can tweak the colors of the generated CSS.
  #
  # config.css.background_color = '#ccc'
  # config.css.text_color = '#444'
  # config.css.active_tab_color = 'white'
  # config.css.hover_tab_color = '#ddd'
  # config.css.inactive_tab_color = '#aaa'
  # config.css.inactive_text_color = '#888'

end

