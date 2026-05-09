# frozen_string_literal: true

class TestController < ApplicationController
  private

    def assign_layout
      @layout = Views::Layouts::Test
    end
end
