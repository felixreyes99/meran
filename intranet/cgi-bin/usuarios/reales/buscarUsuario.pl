#!/usr/bin/perl

use strict;
use C4::AR::Auth;
use CGI;

my $input = new CGI;

my ($template, $session, $t_params) = get_template_and_user({
									template_name => "usuarios/reales/buscarUsuario.tmpl",
									query => $input,
									type => "intranet",
									authnotrequired => 0,
									flagsrequired => {  ui => 'ANY', 
                                                        tipo_documento => 'ANY', 
                                                        accion => 'CONSULTA', 
                                                        entorno => 'usuarios'},
									debug => 1,
			    });

$t_params->{'page_sub_title'}=C4::AR::Filtros::i18n("B&uacute;squeda de Usuarios");

C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);