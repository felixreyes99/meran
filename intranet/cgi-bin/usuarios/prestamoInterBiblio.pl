#!/usr/bin/perl

require Exporter;

use strict;
use CGI;
use C4::AR::PdfGenerator;
use C4::AR::Preferencias;
use C4::AR::Auth;
use C4::AR::Busquedas;


my $input= new CGI;
my $authnotrequired= 0;


# OBTENGO EL BORROWER LOGGEADO Y VERIFICO PERMISOS

my ($template, $session, $t_params);

    
($template, $session, $t_params) = get_template_and_user({
                        template_name => "reports/prestamoInterBiblio-export.tmpl",
                        query => $input,
                        type => "intranet",
                        authnotrequired => 0,
                        flagsrequired => {  ui => 'ANY', 
                                            tipo_documento => 'ANY', 
                                            accion => 'CONSULTA', 
                                            entorno => 'undefined'},
                        debug => 1,
            });


my $nro_socio = $input->param('nro_socio');
my %t_params;
$t_params->{'nro_socio'} = $nro_socio;
C4::AR::Validator::validateParams('U389',$t_params,['nro_socio'] );

my $accion = $input->param('tipoAccion');
my $biblioDestino = C4::AR::Busquedas::getBranch($input->param('name_ui'));

my $director = Encode::decode_utf8($input->param('director'))||"___________________";


my @autores=split("#",$input->param('autores'));
my @titulos=split("#",$input->param('titulos'));
my @otros=split("#",$input->param('otros'));
my @datos;
for(my $i=0;$i<scalar(@titulos);$i++){
    if($i<scalar(@autores)){
        $datos[$i]->{'autor'}=Encode::decode_utf8($autores[$i]);
    }
    else{$datos[$i]->{'autor'}="";}
    if($i<scalar(@otros)){
        $datos[$i]->{'otros'}=Encode::decode_utf8($otros[$i]);
    }
    else{$datos[$i]->{'otros'}="";}
    $datos[$i]->{'titulo'}=Encode::decode_utf8($titulos[$i]);
}

my $socio= C4::AR::Usuarios::getSocioInfoPorNroSocio($nro_socio);
my $branchcode  = C4::AR::Preferencias::getValorPreferencia("defaultUI");
my $biblio      = C4::AR::Busquedas::getBranch($branchcode);



my @datearr = localtime(time);
my $anio = 1900 + $datearr[5];
my $mes  = &C4::Date::mesString( $datearr[4] + 1 );
my $dia  = $datearr[3];

my $fecha= "La Plata ".$dia." de ".$mes." de ".$anio;



$t_params->{'fecha'}= $fecha;

$t_params->{'biblio'}= $biblio;
$t_params->{'socio'}= $socio;
$t_params->{'socio_nombre'}= Encode::decode_utf8($socio->persona->nombre);
$t_params->{'socio_apellido'}=  Encode::decode_utf8($socio->persona->apellido);
$t_params->{'biblio_destino'}= $biblioDestino;
$t_params->{'director'}= $director;
$t_params->{'atencion'}=  C4::AR::Preferencias::getValorPreferencia('open') . " a "
. C4::AR::Preferencias::getValorPreferencia('close');

 my $escudo =
        C4::Context->config('intrahtdocs') . '/temas/'
      . 'default'
      . '/imagenes/escudo-DEFAULT'
      . '.jpg';

  
# ESCUDO UI
    my $escudoUI =
        C4::Context->config('intrahtdocs') . '/temas/'
      . 'default'
      . '/imagenes/escudo-'
      . $branchcode
      . '.jpg';
   

$t_params->{'escudo'}= $escudo;
$t_params->{'escudoUI'}= $escudoUI;

# Encode::decode_utf8(" Sábados: ")
$t_params->{'datos'}= \@datos;


my $out= C4::AR::Auth::get_html_content($template, $t_params, $session);

my $filename= C4::AR::PdfGenerator::pdfFromHTML($out);

print C4::AR::PdfGenerator::pdfHeader();

C4::AR::PdfGenerator::printPDF($filename);


