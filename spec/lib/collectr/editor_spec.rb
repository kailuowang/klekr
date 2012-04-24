require 'spec_helper'

describe Collectr::Editor do

  describe "#recommendation_streams_for" do
    module Enumerable
      def find_similiar_stream(expected_stream)
        self.find do |stream|
          stream.user_id == expected_stream.user_id && stream.is_a?(expected_stream.class)
         end
      end
    end

    before do
      stub_retriever
      @editor_userid = 'euid'
      Settings.stub(:editor_userid).and_return(@editor_userid)
      Settings.stub(:editor_name).and_return('editor')
      @editor = Collectr::Editor.new
      @editor.ensure_editor_collector
      @collector = FactoryGirl.create(:collector)
    end

    it 'includes the collection stream of the user id' do
      @editor.recommendation_streams_for(@collector).find do |stream|
        stream.user_id == @editor_userid && stream.is_a?(FaveStream)
      end.should be_present
    end

    it 'creates streams for the collector' do
      @editor.recommendation_streams_for(@collector).map(&:collector).uniq.should == [@collector]
    end

    it 'creates streams that are not collecting' do
      @editor.recommendation_streams_for(@collector).all?(&:collecting).should be_false
    end

    it 'create the same streams with 4+ star rating streams of the editor collector' do
      editor_stream = FactoryGirl.create(:fave_stream, collector: @editor.editor_collector)
      editor_stream.bump_rating(4)
      @editor.recommendation_streams_for(@collector).find_similiar_stream(editor_stream).should be_present
    end
  end
end