module.exports = {
  apps: [
    {
      name: 'checkmate-api',
      cwd: '/home/ubuntu/checkmate/checkmate-backend',
      script: 'dist/main.js',
      instances: 1,         // 트래픽 늘면 'max' 로 교체해 클러스터 모드 사용
      exec_mode: 'fork',    // Nest 싱글톤 캐시가 많으므로 초기엔 fork 권장
      env: {
        NODE_ENV: 'production',
        PORT: 8080,
        // 나머지 런타임 변수는 checkmate-backend/.env 에서 @nestjs/config 가 읽음.
        // 여기에 중복 선언하지 않아 단일 출처(single source of truth) 유지.
      },
      max_memory_restart: '600M',
      error_file: '/home/ubuntu/checkmate/logs/api.err.log',
      out_file:   '/home/ubuntu/checkmate/logs/api.out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss',
      merge_logs: true,
      kill_timeout: 5000,   // 무중단 reload 시 프로세스 정리 유예(ms)
    },
  ],
}
