#!/usr/bin/perl
use strict;
require Exporter;
use CGI;
use JSON;
use C4::AR::Auth;
use C4::AR::NovedadesIntra;
use C4::AR::Utilidades;

my $input               = new CGI;
my $authnotrequired     = 0;
my $obj                 = $input->param('obj');
$obj                    = C4::AR::Utilidades::from_json_ISO($obj);
my $tipoAccion          = $obj->{'tipoAccion'}||"";


if($tipoAccion eq "MOSTRAR_NOVEDADES"){
    
    my ($template, $session, $t_params)= get_template_and_user({
                                    template_name   => "novedades_intra_result.tmpl",
                                    query           => $input,
                                    type            => "intranet",
                                    authnotrequired => 0,
                                    flagsrequired   => {    ui => 'ANY', 
                                                            tipo_documento => 'ANY', 
                                                            accion => 'CONSULTA', 
                                                            entorno => 'undefined'},
            });


    my $nro_socio                                               = $session->param('nro_socio');            
    my ($cantidad,$grupos)                                      = C4::AR::Nivel1::getUltimosGrupos();
    my ($cantidad_novedades,$novedades)                         = C4::AR::NovedadesIntra::getUltimasNovedades();
    my ($cantidad_novedades_no_mostrar, $novedades_no_mostrar)  = C4::AR::NovedadesIntra::getNovedadesNoMostrar($nro_socio);
    my @novedadesOK;
    my $ok = 0; 

    my $pref_limite = C4::AR::Preferencias::getValorPreferencia('limite_novedades');
    

    if ($cantidad_novedades){
        if($cantidad_novedades < $pref_limite){
            $cantidad_novedades = $cantidad_novedades - $cantidad_novedades_no_mostrar;
        }else{
            $cantidad_novedades = $pref_limite - $cantidad_novedades_no_mostrar;
        }
    }   
  
    
    C4::AR::Debug::debug($cantidad_novedades);
    
    if ($novedades){
      foreach my $nov (@$novedades){
          $ok = 0;
          if($novedades_no_mostrar){
              foreach my $nov_no_mostrar (@$novedades_no_mostrar){  
                  if($nov->getId() == $nov_no_mostrar->getIdNovedad){
                      $ok = 1;
                  }        
              }
          }    
          if(!$ok){
              push(@novedadesOK, $nov);
          }
      }
    } 



    $t_params->{'nro_socio'}            = $nro_socio;
    $t_params->{'SEARCH_RESULTS'}       = $grupos;
    $t_params->{'cantidad'}             = $cantidad_novedades;
    $t_params->{'novedades'}            = \@novedadesOK;

    C4::AR::Auth::output_html_with_http_headers($template, $t_params, $session);
}