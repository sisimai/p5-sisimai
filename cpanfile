requires 'perl', '5.010';
requires 'Class::Accessor::Lite', '0.05';
requires 'Try::Tiny', '0.16';
requires 'JSON', '2.90';
requires 'Time::Local', '1.19';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

on develop => sub {
    requires 'Test::UsedModules', '0.03';
};
