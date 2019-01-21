local Pipeline(arch, os) = {
  kind: 'pipeline',
  name: 'build-on-' + arch + '-' + os,
  platform: {
    os: 'linux',
    arch: arch,
  },
  steps: [
    {
      name: 'build',
      image: 'docker',
      commands: [
        'docker build -t bpftrace-builder-' + arch + '-' + os + ' -f docker/Dockerfile.' + os + ' docker/',
      ],
    },
  ],
  trigger: {
    branch: [
      'ci',
    ],
    event: [
      'push',
    ],
  },
};

[
  Pipeline('amd64', 'fedora29'),
  Pipeline('amd64', 'ubuntu'),
  Pipeline('arm64', 'fedora29'),
  Pipeline('arm64', 'ubuntu'),
]
