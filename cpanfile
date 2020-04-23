requires 'perl', '5.10.1';
requires 'Class::Accessor::Lite', '0.05';
requires 'JSON', '2.90';
requires 'Module::Load', '0.32';
requires 'Time::Local', '1.19';
requires 'Time::Piece', '1.29';

on 'test' => sub {
    requires 'Test::More', '0.98';
};

on 'develop' => sub {
    requires 'Test::UsedModules', '0.03';
};
