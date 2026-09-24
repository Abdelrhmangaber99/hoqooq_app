bool isFirmAdminGrantablePermission(String code) =>
    !code.startsWith('platform.') && !code.startsWith('system.');
