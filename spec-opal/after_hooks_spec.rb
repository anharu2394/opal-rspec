require 'spec_helper'

describe 'hooks' do
  describe 'after' do
    before :all do
      @@total = 0
      @@example_still_in_progress = nil
    end

    after :all do
      expected = 13
      unless @@total == expected
        msg = "Expected #{expected} after hits but got #{@@total}"
        `console.error(#{msg})`
      end
    end

    let(:raise_before_error) { false }

    before do |example|
      if raise_before_error
        @@example_still_in_progress = nil
        raise 'before problem'
      end
      if @@example_still_in_progress
        raise "Another spec (#{@@example_still_in_progress}) is still running, after block problem"
        @@example_still_in_progress = nil
      end
      @@example_still_in_progress = example.description
    end

    let(:raise_after_error) { false }

    context 'sync' do
      after do
        @@total += 1
        @@example_still_in_progress = nil
        raise 'expected after problem' if raise_after_error
      end

      subject { 42 }

      context 'before fails' do
        let(:raise_before_error) { true }

        it 'should not reach the example' do
          fail 'we reached the example and we should not have!'
        end
      end

      context 'match succeeds' do
        context 'sync match' do
          it { is_expected.to eq 42 }
        end

        it 'async match' do
          delay_with_promise 0 do
            expect(subject).to eq 42
          end
        end
      end

      context 'match fails' do
        context 'sync match' do
          it { is_expected.to eq 43 }
        end

        it 'async match' do
          delay_with_promise 0 do
            expect(subject).to eq 43
          end
        end
      end

      context 'after fails' do
        let(:raise_after_error) { true }

        it { is_expected.to eq 42 }
      end

      context 'context' do
        after :context do
          raise 'it failed in the after context!'
        end

        it { is_expected.to eq 42 }
      end
    end

    context 'async' do
      after do
        delay_with_promise 0 do
          @@total += 1
          @@example_still_in_progress = nil
          raise 'after problem' if raise_after_error
        end
      end

      subject do
        delay_with_promise 0 do
          42
        end
      end

      context 'before(:each) fails properly' do
        let(:raise_before_error) { true }

        it { is_expected.to eq 42 }
      end

      context 'match succeeds' do
        context 'sync match' do
          it { is_expected.to eq 42 }
        end

        it 'async match' do
          delay_with_promise 0 do
            expect(subject).to eq 42
          end
        end
      end

      context 'match fails properly' do
        context 'sync match' do
          it { is_expected.to eq 43 }
        end

        it 'async match' do
          delay_with_promise 0 do
            expect(subject).to eq 43
          end
        end
      end

      context 'after(:each) fails properly' do
        let(:raise_after_error) { true }

        it { is_expected.to eq 42 }
      end
    end
  end
end
