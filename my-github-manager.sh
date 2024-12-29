#!/bin/bash

# GitHub API URL
API_URL="https://api.github.com"

# # GitHub username and personal access token (prompt user for input)
# echo -e "\033[1;34mEnter your GitHub username:\033[0m"
# read -r USERNAME
# echo -e "\033[1;34mEnter your GitHub personal access token:\033[0m"
# read -rs TOKEN
# echo ""
# echo -e "\033[1;34mEnsure your GitHub PAT has the following scopes:\033[0m"
# echo "repo, repo:status, repo_deployment, public_repo, repo:invite, security_events,"
# echo ""

# Function to print required scopes
function print_required_scopes {
    echo -e "\033[1;34mEnsure your GitHub API Personal Access Token (PAT) has the following scopes:\033[0m"
    echo -e "\033[1;33mRepository Access Scopes:\033[0m"
    echo -e "  1. \033[1;32mrepo:\033[0m Full control of private repositories"
    echo -e "  2. \033[1;32mrepo:status:\033[0m Access commit status"
    echo -e "  3. \033[1;32mrepo_deployment:\033[0m Access deployment statuses"
    echo -e "  4. \033[1;32mpublic_repo:\033[0m Access public repositories"
    echo -e "  5. \033[1;32mrepo:invite:\033[0m Manage repository invitations"
    echo -e "  6. \033[1;32msecurity_events:\033[0m Read and manage security events"
    
    echo -e "\n\033[1;33mUser Access Scopes:\033[0m"
    echo -e "  1. \033[1;32mread:user:\033[0m Read non-sensitive user profile information"
    echo -e "  2. \033[1;32muser:email:\033[0m Access the user’s email addresses"
    echo -e "  3. \033[1;32muser:follow:\033[0m Follow and unfollow users"
    
    echo -e "\n\033[1;34mTo create a token, visit:\033[0m \033[1;36mhttps://github.com/settings/tokens\033[0m"
}

# Prompt for GitHub username and PAT
echo -e "\033[1;34mEnter your GitHub username:\033[0m"
read -r USERNAME
echo -e "\033[1;34mEnter your GitHub Personal Access Token (PAT):\033[0m"
read -rs TOKEN

# Check if the GitHub PAT works
RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" -u "$USERNAME:$TOKEN" "$API_URL/user")

if [[ "$RESPONSE" -eq 200 ]]; then
    echo -e "\n\033[1;32mAuthentication successful!\033[0m"
else
    echo -e "\n\033[1;31mAuthentication failed! Please check your GitHub username or PAT.\033[0m"
    print_required_scopes
    exit 1
fi


# Function to add color
function print_color {
    local color="$1"
    local message="$2"
    echo -e "${color}${message}\033[0m"
}

# Function to make a GET request to the GitHub API with error handling
function github_api_get {
    local endpoint="$1"
    local url="${API_URL}/${endpoint}"
    
    response=$(curl -s -u "${USERNAME}:${TOKEN}" -w "%{http_code}" -o /tmp/github_api_response "$url")
    http_code=$(tail -n1 <<< "$response")
    body=$(< /tmp/github_api_response)

    if [[ "$http_code" -ge 400 ]]; then
        print_color "\033[1;31m" "Error: Unable to fetch data (HTTP Status: $http_code). Please check your inputs or authentication."
        return 1
    fi

    if [[ -z "$body" ]]; then
        print_color "\033[1;31m" "Error: Empty response received."
        return 1
    fi

    echo "$body"
}

# Function to prompt for repository owner and name
function prompt_repo_info {
    print_color "\033[1;36m" "Enter the repository owner:"
    read -r REPO_OWNER
    print_color "\033[1;36m" "Enter the repository name:"
    read -r REPO_NAME
}

# Function to handle errors and retries
function handle_errors {
    local func_name="$1"
    if ! "$func_name"; then
        print_color "\033[1;33m" "Would you like to retry? (y/n)"
        read -r retry
        if [[ "$retry" == "y" || "$retry" == "Y" ]]; then
            "$func_name"
        fi
    fi
}

# Individual functions for each task
function list_users_with_read_access {
    prompt_repo_info
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/collaborators"
    collaborators=$(github_api_get "$endpoint" | jq -r '.[] | select(.permissions.pull == true) | .login')

    if [[ -z "$collaborators" ]]; then
        print_color "\033[1;31m" "No users with read access found for ${REPO_OWNER}/${REPO_NAME}."
    else
        print_color "\033[1;32m" "Users with read access to ${REPO_OWNER}/${REPO_NAME}:"
        echo "$collaborators"
    fi
}


#function to list packages in a repo
function list_packages {
    prompt_repo_info
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/packages"
    packages=$(github_api_get "$endpoint" | jq -r '.[] | .name')
    if [[ -z "$packages" ]]; then
        print_color "\033[1;31m" "No packages found in ${REPO_OWNER}/${REPO_NAME}."
    else
        print_color "\033[1;33m" "Packages in ${REPO_OWNER}/${REPO_NAME}:"
        echo "$packages"
    fi
}


#dunction to list workflows
function list_workflows {
    prompt_repo_info
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/actions/workflows"
    workflows=$(github_api_get "$endpoint" | jq -r '.workflows[] | .name')
    if [[ -z "$workflows" ]]; then
        print_color "\033[1;31m" "No workflows found in ${REPO_OWNER}/${REPO_NAME}."
    else
        print_color "\033[1;33m" "Workflows in ${REPO_OWNER}/${REPO_NAME}:"
        echo "$workflows"
    fi
}

# Function to list projects in a repository
function list_projects {
    prompt_repo_info
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/projects"
    projects=$(github_api_get "$endpoint" | jq -r '.[] | .name')

    if [[ -z "$projects" ]]; then
        print_color "\033[1;31m" "No projects found in ${REPO_OWNER}/${REPO_NAME}."
    else
        print_color "\033[1;33m" "Projects in ${REPO_OWNER}/${REPO_NAME}:"
        echo "$projects"
    fi
}


# Function to list discussions in a repository

function list_discussions {
  prompt_repo_info
  local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/discussions"
  discussions=$(github_api_get "$endpoint" | jq -r '.[]? | .title')

  if [[ -z "$discussions" ]]; then
    print_color "\033[1;31m" "No discussions found in ${REPO_OWNER}/${REPO_NAME}."
  else
    print_color "\033[1;33m" "Discussions in ${REPO_OWNER}/${REPO_NAME}:"
    echo "$discussions"
  fi
}

# Enhanced error handling for issues
function list_issues {
    prompt_repo_info
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/issues"
    issues=$(github_api_get "$endpoint" | jq -r '.[]? | .title')
    
    if [[ -z "$issues" ]]; then
        print_color "\033[1;31m" "No issues found in ${REPO_OWNER}/${REPO_NAME}."
    else
        print_color "\033[1;33m" "Issues in ${REPO_OWNER}/${REPO_NAME}:"
        echo "$issues"
    fi
}

# Function to list pull requests in a repository
function list_pull_requests {
    prompt_repo_info
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/pulls"
    pull_requests="$(github_api_get "$endpoint" | jq -r '.[] | .title')"
    print_color "\033[1;33m" "Pull Requests in ${REPO_OWNER}/${REPO_NAME}:"
    if [[ -z "$pull_requests" ]]; then
        print_color "\033[1;31m" "No pull requests found."
    else 
        echo "$pull_requests"
    fi
}

# Correct list_actions endpoint and parsing
function list_actions {
    prompt_repo_info
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/actions/runs"
    actions=$(github_api_get "$endpoint" | jq -r '.workflow_runs[]? | .name')
    
    if [[ -z "$actions" ]]; then
        print_color "\033[1;31m" "No actions found in ${REPO_OWNER}/${REPO_NAME}."
    else
        print_color "\033[1;33m" "Actions in ${REPO_OWNER}/${REPO_NAME}:"
        echo "$actions"
    fi
}

#function to follow a user
function follow_user {
    print_color "\033[1;36m" "Enter the username to follow:"
    read -r follow_username
    local endpoint="user/following/$follow_username"
    response=$(curl -s -X PUT -u "${USERNAME}:${TOKEN}" "${API_URL}/${endpoint}")
    if [[ -z "$response" ]]; then
        print_color "\033[1;32m" "Successfully followed $follow_username."
    else
        print_color "\033[1;31m" "Failed to follow $follow_username."
    fi
}


#function to get list_of_emails
function list_user_emails {
    local endpoint="user/emails"
    emails=$(github_api_get "$endpoint" | jq -r '.[].email')
    if [[ -z "$emails" ]]; then
        print_color "\033[1;31m" "No emails found."
    else
        print_color "\033[1;33m" "User Emails:"
        echo "$emails"
    fi
}

#function to list repo invitations
function list_repo_invitations {
    local endpoint="user/repository_invitations"
    invitations=$(github_api_get "$endpoint" | jq -r '.[] | .repository.full_name')

    if [[ -z "$invitations" ]]; then
        print_color "\033[1;31m" "No repository invitations found."
    else
        print_color "\033[1;32m" "Repository invitations:"
        echo "$invitations"
    fi
}

# Function to list all public repositories of a user
function list_public_repos {
    print_color "\033[1;36m" "Enter the GitHub username to fetch public repositories:"
    read -r target_user
    local endpoint="users/${target_user}/repos?type=public"
    
    repos=$(github_api_get "$endpoint" | jq -r '.[] | .name')

    if [[ -z "$repos" ]]; then
        print_color "\033[1;31m" "No public repositories found for user: $target_user."
    else
        print_color "\033[1;33m" "Public repositories of $target_user:"
        echo "$repos"
    fi
}

# Function to get commit history of a public repository
function get_commit_history {
    prompt_repo_info
    local endpoint="repos/${REPO_OWNER}/${REPO_NAME}/commits"
    
    commits=$(github_api_get "$endpoint" | jq -r '.[] | "\(.commit.author.name) - \(.commit.message) - \(.sha)"')

    if [[ -z "$commits" ]]; then
        print_color "\033[1;31m" "No commits found for repository: ${REPO_OWNER}/${REPO_NAME}."
    else
        print_color "\033[1;33m" "Commit history for ${REPO_OWNER}/${REPO_NAME}:"
        echo "$commits"
    fi
}

# Function to fetch and display a user's profile data
function get_user_profile_data {
    print_color "\033[1;36m" "Enter the GitHub username to fetch profile data:"
    read -r target_user
    local endpoint="users/${target_user}"
    
    profile_data=$(github_api_get "$endpoint")

    if [[ -z "$profile_data" ]]; then
        print_color "\033[1;31m" "Failed to fetch profile data for user: $target_user."
    else
        print_color "\033[1;33m" "Profile data for $target_user:"
        echo "$profile_data" | jq '. | {Login: .login, Name: .name, Company: .company, Location: .location, Email: .email, Bio: .bio, Followers: .followers, Following: .following, Created_At: .created_at}'
    fi
}


# Menu loop
while true; do
    echo -e "\033[1;35mChoose an option:\033[0m"
    echo "1. List users with read access (collaborators with pull access)"
    echo "2. List packages in the repository"
    echo "3. List workflows"
    echo "4. List projects"
    echo "5. List discussions"
    echo "6. List issues"
    echo "7. List pull requests"
    echo "8. List actions"
    echo "9. List user emails"
    echo "10. Follow a user"
    echo "11. List repository invitations"
    echo "12. List all public repositories of a user"
    echo "13. Get commit history of a public repository"
    echo "14. Get user profile data"
    echo "15. Exit"
    
 read -rp "Enter your choice: " choice
    case $choice in
        1) handle_errors list_users_with_read_access ;;
        2) handle_errors list_packages ;;
        3) handle_errors list_workflows ;;
        4) handle_errors list_projects ;;
        5) handle_errors list_discussions ;;
        6) handle_errors list_issues ;;
        7) handle_errors list_pull_requests ;;
        8) handle_errors list_actions ;;
        9) handle_errors list_user_emails ;;
        10) handle_errors follow_user ;;
        11) handle_errors list_repo_invitations ;;
        12) handle_errors list_public_repos ;;
        13) handle_errors get_commit_history ;;
        14) handle_errors get_user_profile_data ;;
        15) print_color "\033[1;34m" "Goodbye!"; exit 0 ;;
        *) print_color "\033[1;31m" "Invalid choice. Please try again." ;;
    esac
done