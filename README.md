mod\_filter\_muc\_spam
======================

> _Author:_ Holger Weiss (<holger@zedat.fu-berlin.de>)  
> _Requirements:_ ejabberd 15.06 or newer

In order to use this module, add the following line to the `modules` section of
your `ejabberd.yml` file:

    mod_filter_muc_spam: {}

The configurable options are:

- `strip_body_from_subject` (default: `true`)

  Unless this option is set to `false`, any `<body/>` is removed from groupchat
  messages that include a `<subject/>`.

- `drop_not_registered` (default: `true`)

  Unless this option is set to `false`, groupchat messages with the following
  `<body/>` will be dropped: "The nickname you are using is not registered".
