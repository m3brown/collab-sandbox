#!/bin/bash

librarian_puppet_bin=`which librarian-puppet`
if [ ! -x "$librarian_puppet_bin" ]; then
  gem install librarian-puppet
fi

cd /etc/puppet
librarian-puppet install

