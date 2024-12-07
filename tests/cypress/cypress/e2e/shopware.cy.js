import Shopware from "Services/Shopware";


const shopware = new Shopware();


beforeEach(() => {
    cy.viewport(1920, 1080);
})

describe('Shopware Storefront', () => {

    it('Shopware Storefront is available', () => {

        cy.visit('/');

        cy.contains('Realised with Shopware');
    })

    it('Shopware Storefront navigation is working', () => {

        cy.visit('/');

        cy.get('.nav-item-a515ae260223466f8e37471d279e6406 > .main-navigation-link-text > span').click();

        cy.contains('Main product with properties');
    })

    it('Symfony Debug toolbar is existing', () => {

        cy.visit('/');

        cy.get('.sf-toolbar-icon > .sf-toolbar-status').should('exist');
    })
});


describe('Shopware Administration', () => {

    it('Verify installed Shopware Version: ' + shopware.getVersion(), () => {

        cy.visit('/admin');
        cy.get('#sw-field--username').type('admin');
        cy.get('#sw-field--password').type('shopware');
        cy.get('.sw-button').click();

        cy.contains('.sw-version__info', shopware.getVersion());
    })
})
