gecoscc-chef-server-repo
========================

This chef-repo contains all the needed components (databags, cookbooks, roles...) to make a 'gecoscc-chef-server' from a simple 'chef-server'.

How to deploy a gecoscc-chef-server-repo
========================================

All you need to do is to execute our [install script](https://github.com/gecos-team/gecoscc-chef-server-repo/blob/master/scripts/gecoscc-chef-server-install.sh) which will:

* Install 'rvm'
* Install 'ruby' stable version using 'rvm'
* Install 'chef' gem
* Create chef-solo configuration files in /tmp
* Run 'chef-solo' with [our cookbook](https://raw.github.com/gecos-team/cookbook-gecoscc-chef-server)
* Uninstall 'rvm' (obviously 'chef' gem also)
* Leave your system clean with a 'gecoscc-chef-server' deployed

And of course, the snippet to run the install script:

<pre>
curl -L https://raw.githubusercontent.com/gecos-team/gecoscc-chef-server-repo/master/scripts/gecoscc-chef-server-install.sh | bash
</pre>

That is.

Contributing
============

1.  Fork the repository on Github
2.  Create a named feature branch (like `add_component_x`)
3.  Write your change
4.  Submit a Pull Request using Github

Licence and Authors
=====================

Copyright © 2013 Junta de Andalucia < http://www.juntadeandalucia.es >
Licensed under the EUPL V.1.1

The license text is available at http://www.osor.eu/eupl and the attached PDF

Authors: Roberto C. Morano <rcmorano@emergya.com>
