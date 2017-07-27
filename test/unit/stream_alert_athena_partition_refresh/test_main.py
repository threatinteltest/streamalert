'''
Copyright 2017-present, Airbnb Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
'''

# command: nosetests -v -s test/unit/
# specific test: nosetests -v -s test/unit/file.py:TestStreamPayload.test_name

from collections import namedtuple

from nose.tools import assert_equal, raises

from stream_alert.athena_partition_refresh.main import handler as lambda_handler

def test_handler():
    """Athena - Main"""
    lambda_handler(None, None)

def test_load_config():
    """Athena - Load Config"""
    pass

def test_check_query_status():
    """Athena - Check Query Status"""
    pass

def run_athena_query():
    """Athena - Run Athena Query"""
    pass
