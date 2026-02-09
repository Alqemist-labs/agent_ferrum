# frozen_string_literal: true

module AgentFerrum
  class Node
    MAX_RETRIES = 3

    def initialize(ferrum_node)
      @node = ferrum_node
    end

    def click
      with_retry do
        @node.evaluate("this.scrollIntoView({block: 'center', inline: 'center'})")
        @node.click
      end
    end

    def fill(value)
      with_retry do
        @node.focus
        @node.type(value)
      end
    end

    def select(value)
      with_retry { @node.select(value) }
    end

    def hover
      with_retry do
        @node.evaluate("this.scrollIntoView({block: 'center', inline: 'center'})")
        x, y = @node.find_position
        @node.page.mouse.move(x: x, y: y)
      end
    end

    def focus
      with_retry { @node.focus }
    end

    def text
      @node.text
    end

    def value
      @node.value
    end

    def [](attr)
      @node[attr]
    end

    private

    def with_retry
      attempts = 0
      begin
        attempts += 1
        yield
      rescue Ferrum::NodeMovingError, Ferrum::CoordinatesNotFoundError
        raise if attempts >= MAX_RETRIES

        sleep 0.1
        retry
      end
    end
  end
end
