#                          __ _ _
#   ___ _ __   __ _ _ __  / _(_) | ___
#  / __| '_ \ / _` | '_ \| |_| | |/ _ \
# | (__| |_) | (_| | | | |  _| | |  __/
#  \___| .__/ \__,_|_| |_|_| |_|_|\___|
#      |_|
# - https://perldoc.jp/docs/modules/Module-CPANfile-1.0001/lib/cpanfile.pod
# - https://perldoc.jp/docs/modules/CPAN-Meta-2.132140/lib/CPAN/Meta/Spec.pod#Version32Formats
# -------------------------------------------------------------------------------------------------
# Perl binary and core modules
requires 'perl',         '>= 5.26.0';
requires 'Module::Load', '>= 0.32';
requires 'Time::Local',  '>= 1.19';
requires 'Time::Piece',  '>= 1.29';

# Non-Core modules
requires 'JSON',                  '>= 2.90';
requires 'Class::Accessor::Lite', '>= 0.05';

# -------------------------------------------------------------------------------------------------
on 'test' => sub {
    requires 'Test::More', '0.98';
};

on 'develop' => sub {
    requires 'Test::UsedModules', '0.03';
};

