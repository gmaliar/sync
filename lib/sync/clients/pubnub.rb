module Sync
  module Clients
    class Pubnub
      
      def setup
        require 'logger'
        require 'pubnub'

        @@callback = lambda { |message| Logger.new('log/pubnub.log').debug(message) }
      end

      def batch_publish(*args)
        Message.batch_publish(*args)
      end

      def build_message(*args)
        Message.new(*args)
      end

      def self.callback
        @@callback
      end

      def normalize_channel(channel)
        channel
      end

      class Message

        attr_accessor :channel, :data

        def self.batch_publish(messages)
          messages.each do |message|
            message.publish
          end
        end

        def initialize(channel, data)
          @channel = channel
          @data = data
        end

        def publish
          if Sync.async?
            publish_asynchronous
          else
            publish_synchronous
          end
        end

        def publish_synchronous
          options = { http_sync: true }
          pubnub = ::Pubnub.new(defaults)
          pubnub.publish({:channel  => @channel, :message  => @data}.merge(options))
        end

        def publish_asynchronous
          pubnub = ::Pubnub.new(defaults)
          pubnub.publish(:channel  => @channel, :message  => @data, :callback => Pubnub.callback)
        end

        private
        def defaults
          { publish_key: Sync.pubnub_publish_key, subscribe_key: Sync.pubnub_subscribe_key }
        end
      end
    end
  end
end