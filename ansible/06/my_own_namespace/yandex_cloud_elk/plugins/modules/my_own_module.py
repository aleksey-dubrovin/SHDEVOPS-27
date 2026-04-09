#!/usr/bin/python
# -*- coding: utf-8 -*-

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: my_own_module
short_description: Creates a file with content
description:
  - Creates a file at a specified path with given content.
options:
  path:
    description: Absolute path to the file.
    required: true
    type: str
  content:
    description: Content to write into the file.
    required: true
    type: str
author:
  - Aleksey Dubrovin
'''

EXAMPLES = r'''
- name: Create a file
  my_own_module:
    path: /tmp/example.txt
    content: "Hello, Ansible"
'''

RETURN = r'''
path:
  description: Path to the file
  type: str
content:
  description: Content written
  type: str
'''

from ansible.module_utils.basic import AnsibleModule
import os

def run_module():
    module_args = dict(
        path=dict(type='str', required=True),
        content=dict(type='str', required=True)
    )

    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    path = module.params['path']
    content = module.params['content']

    result = dict(
        changed=False,
        path=path,
        content=content
    )

    # Проверяем существование и содержимое
    file_exists = os.path.exists(path)
    content_matches = False

    if file_exists:
        try:
            with open(path, 'r') as f:
                if f.read() == content:
                    content_matches = True
        except Exception:
            pass

    if not file_exists or not content_matches:
        if not module.check_mode:
            # Создаём директорию, если нужно
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, 'w') as f:
                f.write(content)
        result['changed'] = True

    module.exit_json(**result)

def main():
    run_module()

if __name__ == '__main__':
    main()