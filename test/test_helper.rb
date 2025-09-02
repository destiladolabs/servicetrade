# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "servicetrade"
require "test/unit"
require "webmock"

include WebMock::API
WebMock.enable!
