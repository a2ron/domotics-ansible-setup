# Ansible setup for domotic goodies

You can see this [host inventory sample](hosts.sample)

## Openhab 2
```
ansible-playbook -i hosts.inventory openhab2.yml
 ```
If you want to run just the tasks to update configuration:
> You may want to set ansible var `openhab_backup`, path to openhab backup zip.
```
ansible-playbook -i hosts.inventory openhab2.yml  --tags openhab2-backup
```
In case you want to see available tags:
```
ansible-playbook -i hosts.inventory openhab2.yml  --list-tags

>

  play #1 (all): all    TAGS: []
      TASK TAGS: []

  play #2 (all): all    TAGS: []
      TASK TAGS: [infrastructure, openhab, openhab2, openhab2-backup]
```

## Nginx
```
ansible-playbook -i hosts.inventory nginx.yml
 ```
If you want to run just the tasks to update configuration:
> All the configuration into `files/nginx` will be dumped into `/etc/nginx/`.
```
ansible-playbook -i hosts.inventory nginx.yml  --tags nginx-conf
```

## Deluge Torrent Server and Samba for sharing
```
ansible-playbook -i hosts.inventory torrent.yml
 ```
If you want to run just the tasks to update configuration:
> All the configuration into `files/samba` will be dumped into `/etc/samba/`.

> All the configuration into `files/deluge` will be dumped into `~/.config/deluge/`.
```
ansible-playbook -i hosts.inventory nginx.yml  --tags deluge-conf,samba-conf
```
