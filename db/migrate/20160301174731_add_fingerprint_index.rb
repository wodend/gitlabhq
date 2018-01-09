# rubocop:disable all
class AddFingerprintIndex < ActiveRecord::Migration
  disable_ddl_transaction!

<<<<<<< HEAD
=======
  DOWNTIME = false

>>>>>>> upstream/master
  # https://gitlab.com/gitlab-org/gitlab-ee/issues/764
  def change
    args = [:keys, :fingerprint]

    if Gitlab::Database.postgresql?
      args << { algorithm: :concurrently }
    end

    add_index(*args) unless index_exists?(:keys, :fingerprint)
  end
end
