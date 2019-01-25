---
layout: page
title: About
description: 简洁是智慧的灵魂
keywords: Edgar Teng, Edgar, Tenchael
comments: true
menu: 关于
permalink: /about/
---

This guy have enthusiasm for programming.

## 联系

{% for website in site.data.social %}
* {{ website.sitename }}：[@{{ website.name }}]({{ website.url }})
{% endfor %}

## Skill Keywords

{% for category in site.data.skills %}
### {{ category.name }}
<div class="btn-inline">
{% for keyword in category.keywords %}
<button class="btn btn-outline" type="button">{{ keyword }}</button>
{% endfor %}
</div>
{% endfor %}
