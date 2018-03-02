# coding: utf-8

from datetime import datetime
import logging

from github import Github
from elasticsearch import Elasticsearch
from jira import JIRA


es_host = "localhost"
es_port = "9200"
g_username = ""
g_password = ""
g_org = ""
j_username = ""
j_password = ""
j_host = ""

es = Elasticsearch(["http://{}:{}".format(es_host, es_port)])
github = Github(g_username, g_password)
org = github.get_organization(g_org)
jira = JIRA(j_host, basic_auth=(j_username, j_password))

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
stream_handler = logging.StreamHandler()
stream_handler.setLevel(logging.DEBUG)
logger.addHandler(stream_handler)

now = datetime.now()


def unique(L):
    return list(sorted(list(set(L))))


def get_groups_by_teams(teams):
    return unique([t.name.split("@")[0] for t in teams])
    

def put_github_repositories_info():
    index = now.strftime("github-repos-%Y%m%d")
    doc_type = "main"
    
    for repo in org.get_repos():
        groups = get_groups_by_teams(repo.get_teams())

        _id = repo.name
        doc = {
            "name": repo.name,
            "groups": groups,
            "timestamp": now
        }

        r = es.index(index=index, doc_type=doc_type, id=_id, body=doc)
        logger.info(r)


def put_github_users_info():
    index = now.strftime("github-users-%Y%m%d")
    doc_type = "main"

    teams = {user.login: [] for user in org.get_members()}

    for team in org.get_teams():
        for user in team.get_members():
            teams[user.login].append(team)

    for user in org.get_members():
        groups = get_groups_by_teams(teams[user.login])

        _id = user.login
        doc = {
            "name": user.login,
            "groups": groups,
            "timestamp": now
        }

        r = es.index(index=index, doc_type=doc_type, id=_id, body=doc)
        logger.info(r)


def put_jira_projects_info():
    def get_actors(project):
        actors = []
        for (role_name, role_url) in jira.project_roles(project).items():
            if role_name == "atlassian-addons-project-access":
                continue
            role_id = role_url.rstrip("/").split("/")[-1]
            role = jira.project_role(project, role_id)
            for actor in role.actors:
                actors.append({
                    "name": actor.name,
                    "role": role_name
                })
        return actors
        
    index = now.strftime("jira-projects-%Y%m%d")
    doc_type = "main"

    for project in jira.projects():
        actors = get_actors(project)
        groups = unique([actor["name"] for actor in actors])

        _id = project.key
        doc = {
            "key": project.key,
            "name": project.name,
            "groups": groups,
            "timestamp": now
        }

        r = es.index(index=index, doc_type=doc_type, id=_id, body=doc)
        logger.info(r)


def put_jira_users_info():
    index = now.strftime("jira-users-%Y%m%d")
    doc_type = "main"

    users = jira.group_members("jira-software-users")
    groups = {username: [] for username in users}

    for groupname in jira.groups():
        for username in jira.group_members(groupname):
            groups[username].append(groupname)

    for username in users:
        _id = username
        doc = {
            "name": username,
            "groups": groups[username],
            "timestamp": now
        }

        r = es.index(index=index, doc_type=doc_type, id=_id, body=doc)
        logger.info(r)


if __name__ == "__main__":
    put_github_repositories_info()
    put_github_users_info()
    put_jira_projects_info()
    put_jira_users_info()
