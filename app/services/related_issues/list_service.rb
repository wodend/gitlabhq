module RelatedIssues
  class ListService
    include Gitlab::Routing

    def initialize(issue, user)
      @issue, @current_user = issue, user
    end

    def execute
      issues.map do |referenced_issue|
        {
          title: referenced_issue.title,
          state: referenced_issue.state,
          reference: referenced_issue.to_reference(@issue.project),
          path: namespace_project_issue_path(referenced_issue.project.namespace, referenced_issue.project, referenced_issue.iid)
        }
      end
    end

    private

    def issues
      return @issues if defined?(@issues)

      # TODO: Simplify query using AR
      @issues = Issue.find_by_sql(
        <<-SQL.strip_heredoc
          SELECT issues.*, related_issues.id as related_issues_id FROM issues
          INNER JOIN related_issues ON related_issues.related_issue_id = issues.id
          WHERE related_issues.issue_id = #{@issue.id}
          UNION ALL
          SELECT issues.*, related_issues.id as related_issues_id FROM issues
          INNER JOIN related_issues ON related_issues.issue_id = issues.id
          WHERE related_issues.related_issue_id = #{@issue.id}
          ORDER BY related_issues_id
        SQL
      )

      # TODO: Try to use SQL instead Array#select
      @issues = Ability.issues_readable_by_user(@issues, @current_user)
    end
  end
end
