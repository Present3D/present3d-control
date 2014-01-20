present3d-control
=================

Present3D-Control is an ios-based app to display osg-files and p3d-files. It supports loading
files from the local device via itunes-sharing or loading them from a remote location via http.

It also supports forwarding events via the osc-protocol to control other p3d-presentations on other computers.



Supported environment-variables (via env-tag of the p3d-format):
-------------------------------

* `P3D_CONTROL_ALLOW_TRACKBALL (1|0)` enable/disable the trackball manipulator on the device
* `P3D_CONTROL_MENU_BUTTON_CAPTION (string)` set the caption of the menu-button, can be empty



