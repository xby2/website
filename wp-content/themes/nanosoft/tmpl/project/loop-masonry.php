<?php
defined( 'ABSPATH' ) or die();

$options          = array( 'itemSelector' => '.project' );
$meta_information = (array)nanosoft_option( 'projects__meta' );
?>

	<?php if ( have_posts() ): ?>
		<div class="content" role="main" itemprop="mainContentOfPage">
			<?php get_template_part( 'tmpl/project/filter' ) ?>

			<div class="content-inner" data-grid="<?php echo esc_attr( json_encode( $options ) ) ?>" data-columns="<?php echo esc_attr( nanosoft_option( 'projects__gridColumns' ) ) ?>">
				<?php while ( have_posts() ): the_post(); ?>

					<div <?php post_class( 'project' ) ?> itemscope="itemscope" itemtype="http://schema.org/CreativeWork">
						<div class="project-inner" data-height="project-grid">
							<figure class="project-thumbnail">
								<a class="featured-image" href="<?php the_permalink() ?>">
									<?php if ( $accent_color = get_field( 'projectAccentColor' ) ): ?>
										<span class="mask" style="background-color: <?php echo esc_attr( $accent_color ) ?>;">
											<?php echo esc_html( $accent_color ) ?>
										</span>
									<?php endif ?>

									<?php
										$image = nanosoft_get_image_resized( array(
											'post_id' => get_the_ID(),
											'size'    => nanosoft_option( 'projects__imagesize' ),
											'crop'    => nanosoft_option( 'projects__imagesizeCrop' ) == true
										) );

										echo wp_kses_post( $image['thumbnail'] );
									?>
								</a>
							</figure>

							<div class="project-info">
								<div class="project-info-inner">
									<a href="<?php the_permalink() ?>">
										<h2 class="project-title" itemprop="name headline">
											<?php the_title() ?>
										</h2>

										<?php if ( $client_image_id = get_field( 'projectClientLogo', get_post() ) ): ?>
											<div class="project-client">
												<?php
													$image = nanosoft_get_image_resized( array(
														'image_id' => $client_image_id,
														'size'     => 'full'
													) );

													echo wp_kses_post( $image['thumbnail'] );
												?>
											</div>
										<?php endif ?>
									</a>
								</div>
							</div>
						</div>
					</div>

				<?php endwhile ?>
			</div>
		</div>

		<?php nanosoft_pagination() ?>
	<?php else: ?>
		<!-- Show empty message -->
	<?php endif ?>
