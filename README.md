mod\_filter\_muc\_infos
=======================

> _Author:_ Holger Weiss (<holger@zedat.fu-berlin.de>)  
> _Requirements:_ ejabberd 15.06 or newer

In order to use this module, add the following line to the `modules` section of
your `ejabberd.yml` file:

    mod_filter_muc_infos: {}

The configurable options are:

- `strip_body_from_subject` (default: `true`)

  Unless this option is set to `false`, any `<body/>` is removed from groupchat
  messages that include a `<subject/>`.

- `drop_info_messages` (default: `true`)

  Unless this option is set to `false`, groupchat messages with either of the
  following `<body/>` contents will be dropped:

  - "The nickname you are using is not registered"
  - "This room is not anonymous"
