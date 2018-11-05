from locust import HttpLocust, TaskSet
from lxml import html

def login(l):
    r=l.client.get("login")
    tree=html.fromstring(r.text)
    print tree
    i=tree.xpath('//input[@name="authenticity_token"]')
    token=i[0].value
    l.client.post("login", {"username":"user", "password":"28ukhN6yttx5", "authenticity_token":token})

def logout(l):
    l.client.get("logout")

def index(l):
    l.client.get("")

def mypage(l):
    l.client.get("my/page")


class UserBehavior(TaskSet):
    tasks = {index: 2, mypage: 1}

    def on_start(self):
        login(self)

    def on_stop(self):
        logout(self)

class WebsiteUser(HttpLocust):
    task_set = UserBehavior
    min_wait = 5000
    max_wait = 9000

